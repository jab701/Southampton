import os
import re
import sys
from sqlobject import *
import MySQLdb
import string
# Import smtplib for the actual sending function
import smtplib

# Import the email modules we'll need
from email.mime.text import MIMEText


class EmailAddress(SQLObject):
    Email = StringCol(length=1000, unique=True)
    cfp   = BoolCol(default=0)
    cfp2  = IntCol(default=0)
    
def sql_connect(dbuser,dbpass,dbhost,dbdb):
    connStr = "mysql://" + dbuser + ":" + dbpass + "@" + dbhost + "/" + dbdb
    sqlhub.processConnection = connectionForURI(connStr)
    
def grab_email(file):
    """Try and grab all emails addresses found within a given file."""
    email_list = []
    email_pattern = re.compile(r'\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b',re.IGNORECASE)
    found = set()
    if os.path.isfile(file):
        for line in open(file, 'r'):
            found.update(email_pattern.findall(line))
    for email_address in found:
        tmpstr = email_address.lower()
        email_list.append(tmpstr)
    return email_list

def get_all_addresses_by_emailsnotsent(ColName):
    statement = ColName + "=0"
    Returned_Emails = EmailAddress.select(statement)
    return Returned_Emails
    
def get_all_addresses_by_emails():
    Returned_Emails = EmailAddress.select()
    return Returned_Emails    
    

    
    
if __name__ == '__main__':
    conn = sql_connect('feda','rohu20taco','mysql3.ecs.soton.ac.uk','feda')
    EmailAddress.createTable(ifNotExists=True)

    if (sys.argv[1] == 'add'):
        email_list = grab_email(sys.argv[2])
        for email in email_list:
            try:
                Email1 = EmailAddress(Email = email)
            except dberrors.DuplicateEntryError:
                print email + " already exists, skipping"
                
    elif (sys.argv[1] == "testsend"):
        TestEmails = ("tjk@ecs.soton.ac.uk","prw@ecs.soton.ac.uk","jab@ecs.soton.ac.uk")
        # Open a plain text file for reading.  For this example, assume that
        # the text file contains only ASCII characters.
        filename = sys.argv[2] + ".txt"
        fp = open(filename, 'rb')
        # Create a text/plain message
        subject = fp.readline();
        fp.readline();
        msg = MIMEText(fp.read())
        fp.close()

        msg['Subject'] = "TEST " + subject

        server = smtplib.SMTP('smtp.ecs.soton.ac.uk')
        server.sendmail("feda@ecs.soton.ac.uk", TestEmails, msg.as_string())
        server.quit()
        
    elif (sys.argv[1] == "send"):
    
    	if (sys.argv[2] == "ignore"):
    		Emails = get_all_addresses_by_emails()
    		print "Number of addresses to be sent a " + sys.argv[3] + " email: = " + str(Emails.count())
    		filename = sys.argv[3] + ".txt"
    	else:
        	Emails = get_all_addresses_by_emailsnotsent(sys.argv[2]);
        	print "Number of addresses that have not been sent a " + sys.argv[2] + " email: = " + str(Emails.count())
        	filename = sys.argv[2] + ".txt"

        # Open a plain text file for reading.  For this example, assume that
        # the text file contains only ASCII characters.
        
        fp = open(filename, 'rb')
        # Create a text/plain message
        subject = fp.readline();
        fp.readline();
        msg = MIMEText(fp.read())
        fp.close()

        msg['Subject'] = subject

        server = smtplib.SMTP('smtp.ecs.soton.ac.uk')

        for address in Emails:
            try:
                server.sendmail("[no-reply]feda@ecs.soton.ac.uk", address.Email, msg.as_string())
                address.cfp = address.cfp + 1
            except smtplib.SMTPRecipientsRefused:
                print "Recipient: " + address.Email + " has been refused by the server"
                
        server.quit()   
            

        

        
