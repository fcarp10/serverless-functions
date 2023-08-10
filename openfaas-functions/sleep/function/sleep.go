package function

import (
	"strconv"
	"time"
)

func ProcessRequest(data string) string {
	n, err := strconv.Atoi(data)
	if err == nil {
		time.Sleep(time.Duration(n) * time.Millisecond)
		return "done!"
	} else {
		return "wrong input!"
	}
}
