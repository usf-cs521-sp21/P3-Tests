test_file_name="$(basename "${0}")"
test_num="${test_file_name%%-*}"
test_pts="${test_file_name##*-}"
test_pts="${test_pts/.sh/}"
test_pts="${test_pts/.c/}"
test_name="${test_file_name%-*}"
test_name="${test_name##*-}"
in_test=false
program_output=""
filtered_output=""
reference_output=""
run_timeout=0

exec &> "${TEST_DIR}/outputs/${test_num}.md"

test_start() {
    if [[ ${in_test} == true ]]; then
        echo "FATAL: Entering test block failed: missing 'test_end'?"
        exit 1
    fi
    in_test=true
    ((test_count++))
    echo "## Test ${test_num}: ${1} [${test_pts} pts]"
    if [[ -n ${2} ]]; then
        echo
        echo "${2}"
    fi
    echo
    echo '```'
    trace_on
}

test_checks() {
    return="${1}"

    if [[ "${return}" -eq 139 ]]; then
        echo '--------------------------------------------'
        echo ' --> ERROR: program terminated with SIGSEGV '
        echo '--------------------------------------------'
        echo
    fi

    if [[ "${return}" -eq 124 ]]; then
        echo '--------------------------------------------'
        echo " --> ERROR: program timed out (${run_timeout}s) "
        echo '--------------------------------------------'
        echo
    fi

    if [[ ${return} -ne 0 ]]; then
        echo "**Test failed** (${return})"
    fi
}

test_end() {
    return=${?}
    if [[ -n ${1} ]]; then
        return=${1}
    fi

    if [[ "${return}" -eq 139 ]]; then
        echo '--------------------------------------------'
        echo ' --> ERROR: program terminated with SIGSEGV '
        echo '--------------------------------------------'
        echo
    fi

    if [[ "${return}" -eq 124 ]]; then
        echo '--------------------------------------------'
        echo " --> ERROR: program timed out (${run_timeout}s) "
        echo '--------------------------------------------'
        echo
    fi

    if [[ ${return} -ne 0 ]]; then
        echo " --> Test failed (${return})"
    fi

    { trace_off; } 2> /dev/null
    in_test=false
    echo -e '```'"\n"
    exit "${return}"
}

trace_on() {
    set -v
}

trace_off() {
    { set +v; } 2> /dev/null
}

run() {
    program_output=$(timeout ${run_timeout} "${@}")
    program_return=$?

    if [[ "${program_return}" -ne 0 ]]; then
        test_end "${program_return}"
    else
        return 0
    fi
}

reference_run() {
    reference_output=$("${@}")
    return $?
}

filter() {
    filtered_output=$(grep -iE ${@} <<< "${program_output}")
    matches=0
    if [[ -n "${filtered_output}" ]]; then
        matches=$(wc -l <<< "${filtered_output}") 
    fi
    echo " --> Filter matched ${matches} line(s)"
}

draw_sep() {
    local term_sz="$(tput cols)"
    local half=$(((term_sz - 1) / 2))
    local midpoint="${1}"
    if [[ -z "${midpoint}" ]]; then
        midpoint='-'
    fi

    for (( i = 0 ; i < half ; ++i )); do
        echo -n "-"
    done
    echo -n "${midpoint}"
    for (( i = 0 ; i < (( half - (term_sz % 2))); ++i )); do
        echo -n "-"
    done
    echo
}

compare_outputs() {
    compare ${@} <(echo "${reference_output}") <(echo "${program_output}")
}

compare() {
    echo
    local term_sz="$(tput cols)"
    local half=$(((term_sz - 1) / 2))
    printf "%-${half}s| %s\n" "Expected Program Output" "Actual Program Output"
    draw_sep 'V'
    sdiff --expand-tabs --width="${term_sz}" "${@}"
    local result=${?}
    draw_sep '^'
    echo -n " --> "
    if [[ ${result} -eq 0 ]]; then
        echo "OK"
    else
        echo "FAIL"
    fi
    return ${result}
}

