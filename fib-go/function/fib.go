package function

import (
	"strconv"
)

func ProcessRequest(data string) string {
	n, err := strconv.ParseUint(data, 10, 64)
	if err == nil {
		return strconv.FormatUint(fib(n), 10)
	} else {
		return "wrong input!"
	}
}

func fib(n uint64) uint64 {
	if n <= 1 {
		return 1
	}
	return fib(n-1) + fib(n-2)
}
