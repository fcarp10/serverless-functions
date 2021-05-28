package function

import (
	"encoding/json"
	"log"
	"sync"
	"time"

	"github.com/nats-io/nats.go"
	"github.com/nats-io/nats.go/bench"
)

var benchmark *bench.Benchmark

type content struct {
	Url     string
	NumPubs int
	NumSubs int
	NumMsgs int
	MsgSize int
	Topic   string
}

func ProcessRequest(data string) string {
	request := ConvertJson(data)
	return RunBench(request)
}

func ConvertJson(jsonM string) content {

	var message content
	err := json.Unmarshal([]byte(jsonM), &message)
	if err != nil {
		log.Fatalf("Error occurred when unmarshaling. Error: %s", err.Error())
	}
	return message
}

func RunBench(m content) string {

	benchmark = bench.NewBenchmark("NATS", m.NumSubs, m.NumPubs)

	var startwg sync.WaitGroup
	var donewg sync.WaitGroup

	donewg.Add(m.NumPubs + m.NumSubs)

	// Run Subscribers first
	startwg.Add(m.NumSubs)
	for i := 0; i < m.NumSubs; i++ {
		nc, err := nats.Connect(m.Url)
		if err != nil {
			log.Fatalf("Can't connect: %v\n", err)
		}
		defer nc.Close()

		go runSubscriber(nc, &startwg, &donewg, m.NumMsgs, m.MsgSize, m.Topic)
	}
	startwg.Wait()

	// Now Publishers
	startwg.Add(m.NumPubs)
	pubCounts := bench.MsgsPerClient(m.NumMsgs, m.NumPubs)
	for i := 0; i < m.NumPubs; i++ {
		nc, err := nats.Connect(m.Url)
		if err != nil {
			log.Fatalf("Can't connect: %v\n", err)
		}
		defer nc.Close()

		go runPublisher(nc, &startwg, &donewg, pubCounts[i], m.MsgSize, m.Topic)
	}

	log.Printf("Starting benchmark [msgs=%d, msgsize=%d, pubs=%d, subs=%d]\n", m.NumMsgs, m.MsgSize, m.NumPubs, m.NumSubs)

	startwg.Wait()
	donewg.Wait()

	benchmark.Close()

	// fmt.Print(benchmark.Report())
	log.Printf("Pub: %s", benchmark.Pubs.Statistics())
	log.Printf("Sub: %s", benchmark.Subs.Statistics())
	return benchmark.CSV()
}

func runPublisher(nc *nats.Conn, startwg, donewg *sync.WaitGroup, numMsgs int, msgSize int, subj string) {
	startwg.Done()

	var msg []byte
	if msgSize > 0 {
		msg = make([]byte, msgSize)
	}

	start := time.Now()

	for i := 0; i < numMsgs; i++ {
		nc.Publish(subj, msg)
	}
	nc.Flush()
	benchmark.AddPubSample(bench.NewSample(numMsgs, msgSize, start, time.Now(), nc))

	donewg.Done()
}

func runSubscriber(nc *nats.Conn, startwg, donewg *sync.WaitGroup, numMsgs int, msgSize int, subj string) {

	received := 0
	ch := make(chan time.Time, 2)
	sub, _ := nc.Subscribe(subj, func(msg *nats.Msg) {
		received++
		if received == 1 {
			ch <- time.Now()
		}
		if received >= numMsgs {
			ch <- time.Now()
		}
	})
	sub.SetPendingLimits(-1, -1)
	nc.Flush()
	startwg.Done()

	start := <-ch
	end := <-ch
	benchmark.AddSubSample(bench.NewSample(numMsgs, msgSize, start, end, nc))
	nc.Close()
	donewg.Done()
}
