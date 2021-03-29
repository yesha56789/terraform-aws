from flask import Flask
import socket
import mysql.connector

app = Flask(__name__)


@app.route('/')
def hello():
    hostname = socket.gethostname()
    local_ip = socket.gethostbyname(hostname)
    

    cnx = mysql.connector.connect(user='admin', password='Test1234',
                              host='app.cvbg9ndhvah9.ap-south-1.rds.amazonaws.com',
                              database='app')
    mycursor = cnx.cursor()
    query = "INSERT INTO hostdetails (hostname) VALUES ({})".format(local_ip)
    mycursor.execute(query)
    return 'Hello World'

if __name__ == '__main__':
    app.run(host='0.0.0.0')
