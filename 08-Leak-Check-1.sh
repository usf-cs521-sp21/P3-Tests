source "${TEST_DIR}/lib/funcs.bash"

fd_check='
{
    if (/==[0-9]*==\s*Open file descriptor/) {
        fd=$0;
        getline;
        if (! /inherited/) {
            print fd
        }
    }
}' 

rand=${RANDOM}
script=$(cat <<EOM
ls /
!1


jobs
cd
ls / # Doing some more lsing
!!
asdfghjklqprewopiqwualasdf # Bad Command!
# Comment only
pwd
echo hi
sort -r -n < /etc/passwd > /tmp/$rand
rm /tmp/$rand
history
!p


echo bye
EOM
)

test_start "Memory Leak Check"

if ! ( which valgrind &> /dev/null ); then
    # "valgrind is not installed. Please install (as root) with:"
    # "pacman -Sy valgrind"
    test_end 1
fi

leak_output=$(timeout 10 valgrind \
    --trace-children=no \
    --child-silent-after-fork=yes \
    --leak-check=full \
    --track-fds=yes \
    --show-leak-kinds=all \
    --track-origins=yes \
    ./$SHELL_NAME < <(echo "${script}") 2>&1)

echo "${leak_output}"

# Check for open FDs
awk "${fd_check}" <<< "${leak_output}" \
    | grep -i '==[0-9]*==.*file descriptor' && test_end 1

# Make sure there were no leaks possible
grep -i '==[0-9]*==.*no leaks are possible' \
    <<< "${leak_output}" || test_end 1

# If none of the conditions were triggered above, the test passes.
test_end 0
