source "${TEST_DIR}/lib/funcs.bash"

mine_tester() {
    block='This is a test!'
    threads="${1}"
    difficulty="${2}"
    output=$(./miner "${threads}" "${difficulty}" "${block}")
    echo "${output}"
    nonce=$(grep 'Nonce:' <<< "${output}" | awk '{print $2}')
    sha1=$(echo -n "${block}${nonce}" | sha1sum)
    zeros=0
    for i in $(sed -e 's/\(.\)/\1\n/g' <<< "${sha1}"); do
        if [[ "${i}" == "0" ]]; then
            (( zeros++ ))
        else
            break
        fi
    done
    (( zeros = zeros * 4 ))
    echo "Found ${zeros} leading zeros"

    echo ; echo ; echo

    if [[ ${zeros} -ge ${difficulty} ]]; then
        return 0
    else
        test_end 1
    fi
}

test_start "Correct Nonces" \
    "Verifies program solutions against known-correct nonces"

mine_tester 1   4
mine_tester 8   4
mine_tester 100 4
mine_tester 6   8
mine_tester 2   12
mine_tester 4   12
mine_tester 3   16
mine_tester 4   20

test_end
