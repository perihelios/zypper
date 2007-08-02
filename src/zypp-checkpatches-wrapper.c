/* A setuid-root wrapper for zypper refresh repositories */

/* clearenv */
#include <stdlib.h>
/* chdir, execl, setuid */
#include <unistd.h>
/* perror */
#include <stdio.h>

#define WRAPPER_ERROR 101

const char *app = "/usr/bin/zypper";
const char *arg1 = "--non-interactive";
const char *arg2 = "--terse";
const char *arg3 = "-q";
const char *arg4 = "xu";

int main (void) {
    /* cd / to avoid NFS problems */
    if (chdir ("/")) {
	perror ("chdir");
	return WRAPPER_ERROR;
    }
    /* do not look at argv... done */
    /* clear environment */
    if (clearenv ()) {
	fprintf (stderr, "clearenv failed\n");
	return WRAPPER_ERROR;
    }
    /* set minimal environment... done */
    /* prevent the user from sending signals */
    if (setuid (0)) {
	perror ("setuid");
	fprintf (stderr, "Forgot to chmod this program?\n");
	fprintf (stdout, "<?xml version='1.0'?>\n");
	fprintf (stdout, "<update-status version=\"0.5\">\n");
	fprintf (stdout, " <errors>");
	fprintf (stdout, "  <error>Unable to check for patches and updates because /usr/sbin/zypp-checkpatches-wrapper helper programm is not set SUID root.\nThis problem might be solved by setting \"File Permissons\" in YaST \"Local Security\" tab to \"easy\" or by modifying /etc/permissions.local</error>");
	fprintf (stdout, " </errors>");
	fprintf (stdout, " </update-status>");
	return WRAPPER_ERROR;
    }
 
    /* execute the real application */
    execl (app, app, arg1, arg2, arg3, arg4, (char *) NULL);

    /* if we are still here, it has failed */
    perror ("exec");
    return WRAPPER_ERROR;
}
