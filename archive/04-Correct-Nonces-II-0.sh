source "${TEST_DIR}/lib/funcs.bash"

mine_tester() {
    ./miner "${@}" | grep 'Nonce:' | awk '{print $2}'
}

check_nonce() {
    echo -n "Expected nonce: ${1}; Actual: ${2}"
    if [[ ${1} -eq ${2} ]]; then
        echo " --- [ OK! ]"
        return 0
    else
        echo " --- [ FAIL ]"
        return 1
    fi
}

test_start "Correct Nonces" \
    "Verifies program solutions against known-correct nonces"

nonce=$(mine_tester 1 5 'This is a test! (1)')
check_nonce 5 ${nonce} || test_end 1

nonce=$(mine_tester 128 5 'This is a test! (1)')
check_nonce 5 ${nonce} || test_end 1

nonce=$(mine_tester 1 10 'This is a test! (2)')
check_nonce 780 ${nonce} || test_end 1

nonce=$(mine_tester 4 10 'This is a test! (2)')
check_nonce 780 ${nonce} || test_end 1

nonce=$(mine_tester 1 19 'This is a test! (3)')
check_nonce 648157 ${nonce} || test_end 1

nonce=$(mine_tester 2 19 'This is a test! (3)')
check_nonce 648157 ${nonce} || test_end 1

test_end
