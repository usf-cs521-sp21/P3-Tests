source "${TEST_DIR}/lib/funcs.bash"

test_threads() {
    num_threads=${1}
    echo "Testing ${num_threads} threads..."

    ./miner ${1} 32 'Test Case 2' &
    pid=${!}
    sleep 0.5
    threads_found=$(ls -1 /proc/${pid}/task | wc -l)
    kill -9 ${pid}

    expected1=$(( num_threads + 1 ))
    expected2=$(( num_threads + 2 ))

    if [[ ${threads_found} -eq ${expected1} \
        || ${threads_found} -eq ${expected2} ]]; then
        echo "Threads: ${threads_found}"
        echo "Correct number of threads! (${expected1} / ${expected2})"
        return 0
    else
        echo "Threads: ${threads_found}"
        echo "Incorrect number of threads! (${expected1} / ${expected2})"
        return 1
    fi
}

test_start "Thread Creation" \
    "Ensures the program creates the desired number of threads"

timeout 1 ./miner 0 32 'Test Case 2' &> /dev/null
result=${?}
if [[ ${result} -ne 1 ]]; then
    echo "Return was: ${result}; should be 1 (invalid number of threads)"
    test_end 1
fi

timeout 1 ./miner bananas 32 'Test Case 2' &> /dev/null
result=${?}
if [[ ${result} -ne 1 ]]; then
    echo "Return was: ${result}; should be 1 (invalid number of threads)"
    test_end 1
fi

test_threads 128
test_threads 64
test_threads 1
test_threads 10
test_threads 13

test_end
