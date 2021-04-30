source "${TEST_DIR}/lib/funcs.bash"

test_start "Difficulty Calculation" \
    "Checks for the correct number of leading zeros"

program_output=$(stdbuf -o0 timeout 0.5 ./miner 1 5 'Test Case 1')
reference_output="Difficulty Mask: 00000111111111111111111111111111"
compare --ignore-all-space \
    <(echo "${reference_output}") \
    <(echo "${program_output}" | grep 'Difficulty Mask:')


program_output=$(stdbuf -o0 timeout 0.5 ./miner 1 1 'Test Case 1')
reference_output="Difficulty Mask: 01111111111111111111111111111111"
compare --ignore-all-space \
    <(echo "${reference_output}") \
    <(echo "${program_output}" | grep 'Difficulty Mask:')


program_output=$(stdbuf -o0 timeout 0.5 ./miner 1 32 'Test Case 1')
reference_output="Difficulty Mask: 00000000000000000000000000000000"
compare --ignore-all-space \
    <(echo "${reference_output}") \
    <(echo "${program_output}" | grep 'Difficulty Mask:')


program_output=$(stdbuf -o0 timeout 0.5 ./miner 1 30 'Test Case 1')
reference_output="Difficulty Mask: 00000000000000000000000000000011"
compare --ignore-all-space \
    <(echo "${reference_output}") \
    <(echo "${program_output}" | grep 'Difficulty Mask:')

test_end
