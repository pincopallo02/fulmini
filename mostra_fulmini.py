# -*- coding: utf-8 -*-
"""
Created on Tue Oct  2 10:07:26 2018

@author: mmussin
"""
from flask import Flask
from flask import render_template
from flask_s3 import FlaskS3
app = Flask(__name__)
app.config['FLASKS3_BUCKET_NAME']='lampinet'
app.config['AWS_ACCESS_KEY_ID']='ACCESS_KEY'
app.config['AWS_SECRET_ACCESS_KEY']='SECRET_KEY'

s3=FlaskS3(app)
@app.route("/")
def hello():
    return render_template('fulmini2.html')