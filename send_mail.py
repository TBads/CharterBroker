import sys, smtplib
from secure_info import gmail_user, gmail_app_pwd

def send_email(recipient, subject, body):

    FROM = gmail_user
    TO = recipient if type(recipient) is list else [recipient]
    SUBJECT = subject
    TEXT = body

    # Prepare actual message
    message = """From: %s\nTo: %s\nSubject: %s\n\n%s
    """ % (FROM, ", ".join(TO), SUBJECT, TEXT)
    try:
        server = smtplib.SMTP("smtp.gmail.com", 587)
        server.ehlo()
        server.starttls()
        server.login(gmail_user, gmail_app_pwd)
        server.sendmail(FROM, TO, message)
        server.close()
        print 'successfully sent the mail'
    except Exception as e:
        print "failed to send mail"
        print str(e)
        None

if __name__ == "__main__":
  send_email(
      recipient = sys.argv[1],
      subject = sys.argv[2],
      body = sys.argv[3]
  )
