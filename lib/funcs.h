#ifndef _FUNCS_H_
#define _FUNCS_H_

#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void test_flush(void);

static int subtests = 0;
static int subtests_fail = 0;
static int subtest_assert_fail = 0;

#define test_start(description, ...) \
int main(void) { test_setup(description);

#define test_end \
    if (subtests_fail > 0) { \
        printf("%d of %d subtests failed.\n", subtests_fail, subtests); \
    } \
    /* Invert for shell-style return code */  \
    return subtests_fail != 0; \
	}

#define test_assert(cond, desc...) \
    do { \
        test_flush(); \
        puts(""); \
        char *description = "" desc; \
        if (strcmp(description, "") != 0) { \
            printf("> %s\n", description); \
        } \
        printf("> Assertion: %s [ %s ]\n", #cond, cond ? " OK " : "FAIL"); \
        if (!(cond)) { subtest_assert_fail++; } \
        test_flush(); \
    } while (0)

#define test_assert_floateq(float1, float2, threshold, desc...) \
    do { \
        test_flush(); \
        puts(""); \
        char *description = "" desc; \
        if (strcmp(description, "") != 0) { \
            printf("> %s\n", description); \
        } \
        bool cond = (fabs(float1 - float2) < threshold); \
        printf("> Assertion: %s == %s (threshold: %f) [ %s ]\n", \
            #float1, #float2, threshold, cond ? " OK " : "FAIL"); \
        if (!(cond)) { subtest_assert_fail++; } \
        test_flush(); \
    } while (0)

#define test_printf(fmt, var) \
    do { \
        test_flush(); \
        printf("> %s: "fmt"\n", #var, var); \
        test_flush(); \
    } while (0)

#define test_assert_str(str1, cmp, str2, maxlen, desc...) \
    do { \
        test_flush(); \
        char *description = "" desc; \
        if (strcmp(description, "") != 0) { \
            printf("> %s\n", description); \
        } \
        int comparison = 0; \
        if (strcmp(cmp, "!=") == 0) { \
            comparison = 1; \
        } \
        bool cond = strncmp(str1, str2, maxlen) == comparison; \
        printf("> Assertion: %s %s '%s' [ %s ]\n", \
            #str1, cmp, str2, cond ? " OK " : "FAIL"); \
        if (!cond) { subtest_assert_fail++; } \
        test_flush(); \
    } while (0)

#define subtest(description, ...) \
	do { \
		printf("### Subtest %02d: %s\n", ++subtests, description); \
		subtest_assert_fail = 0; \
		puts("```"); \
		test_flush(); \
		__VA_ARGS__ \
		test_flush(); \
		printf("\n--> Subtest %s\n", subtest_assert_fail == 0 ? "passed" : "failed"); \
		if (subtest_assert_fail != 0) { \
			subtests_fail++; \
		} \
		puts("```"); \
		puts(""); \
	} while (0)

void test_setup(char *description)
{
    char *num = getenv("test_num");
    char *name = getenv("test_name");
    char *pts = getenv("test_pts");

    printf("## Test %s: %s [%s pts]\n\n", num, name, pts);
    if (description != NULL) {
        printf("%s\n\n", description);
    }

    test_flush();
}

void test_flush(void)
{
    fflush(stdout);
    fflush(stderr);
}

#endif
