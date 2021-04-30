import urllib
import numpy as np
import mysql.connector
import cv2
import pyttsx3
import pickle
from datetime import datetime
import sys
import PySimpleGUI as sg
import webbrowser

# 1 Create database connection
myconn = mysql.connector.connect(host="localhost", user="root", passwd="clearlove7", database="facerecognition")
date = datetime.utcnow()
now = datetime.now()
current_time = now.strftime("%H:%M:%S")
cursor = myconn.cursor()

#themestart
theme_name_list = sg.theme_list()
#themeend

# 2 Load recognize and read label from model
recognizer = cv2.face.LBPHFaceRecognizer_create()
recognizer.read("train.yml")

labels = {"person_name": 1}
with open("labels.pickle", "rb") as f:
    labels = pickle.load(f)
    labels = {v: k for k, v in labels.items()}

# create text to speech
engine = pyttsx3.init()
rate = engine.getProperty("rate")
engine.setProperty("rate", 175)

# Define camera and detect face
face_cascade = cv2.CascadeClassifier('haarcascade/haarcascade_frontalface_default.xml')
cap = cv2.VideoCapture(0)

# 3 Define pysimplegui setting
sg.theme('DarkBlue')
layout = [
    [sg.Text('Setting', size=(18, 1), font=('Any', 18), justification='left')],
    [sg.Text('Confidence'),
     sg.Slider(range=(0, 100), orientation='h', resolution=1, default_value=60, size=(15, 15), key='confidence')],
    [sg.OK(), sg.Cancel()]
]
win = sg.Window('Attendance System',
                default_element_size=(21, 1),
                text_justification='right',
                auto_size_text=False).Layout(layout)
event, values = win.Read()
if event is None or event == 'Cancel':
    exit()
args = values
gui_confidence = args["confidence"]
win_started = False

# 4 Open the camera and start face recognition
while True:
    ret, frame = cap.read()
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.5, minNeighbors=5)

    for (x, y, w, h) in faces:
        print(x, w, y, h)
        roi_gray = gray[y:y + h, x:x + w]
        roi_color = frame[y:y + h, x:x + w]
        # predict the id and confidence for faces
        id_, conf = recognizer.predict(roi_gray)

        # If the face is recognized
        if conf >= gui_confidence:
            # print(id_)
            # print(labels[id_])
            font = cv2.QT_FONT_NORMAL
            id = 0
            id += 1
            name = labels[id_]
            current_name = name
            color = (255, 0, 0)
            stroke = 2
            cv2.putText(frame, name, (x, y), font, 1, color, stroke, cv2.LINE_AA)
            cv2.rectangle(frame, (x, y), (x + w, y + h), (255, 0, 0), (2))

            # Find the student information in the database.
            select = "SELECT uid, name, DAY(login_date), MONTH(login_date), YEAR(login_date) FROM Student WHERE name='%s'" % (
                name)
            name = cursor.execute(select)
            result = cursor.fetchall()
            # print(result)
            data = "error"

            for x in result:
                data = x

            # If the student's information is not found in the database
            if data == "error":
                # the student's data is not in the database
                print("The student", current_name, "is NOT FOUND in the database.")
                win.Close()
                cap.release()

            # If the student's information is found in the database
            else:
                """
                Implement useful functions here.
                Check the course and classroom for the student.
                    If the student has class room within one hour, the corresponding course materials
                        will be presented in the GUI.
                    if the student does not have class at the moment, the GUI presents a personal class 
                        timetable for the student.

                """

#@ start 1
                def showCourses(result):
                    header_list = ['Course name', 'Class information', 'Teacher', 'Class date', 'ZoomUrl', 'Classroom',
                                   'Starting time', 'Material link']
                    #############################################
                    sg.theme(theme_name_list[data[0]])
                    layout = [
                        [sg.Text('all courses')],
                        [sg.Table(values=result,
                                  headings=header_list,
                                  max_col_width=25,
                                  auto_size_columns=True,
                                  justification='left',
                                  )]
                    ]

                    win = sg.Window('No class near, Showing All Courses', layout)
                    event, values = win.Read()

                def show_course_details(cs):
                    sg.theme(theme_name_list[data[0]])
                    layout = [
                        [sg.Text("Course name:", size=(20, 2), font=('Any', 12, 'bold'), text_color='#00ff00'),
                         sg.Text("{}".format(cs[0]), size=(40, 2), font=('Any', 12))],
                        [sg.Text("Class information:", size=(20, 2), font=('Any', 12, 'bold'), text_color='#00ff00'),
                         sg.Text("{}".format(cs[1]), size=(40, 2), font=('Any', 12))],
                        [sg.Text("Teacher:", size=(20, 2), font=('Any', 12, 'bold'), text_color='#00ff00'),
                         sg.Text("{}".format(cs[2]), size=(40, 2), font=('Any', 12))],
                        [sg.Text("Zoom Url:", size=(20, 2), font=('Any', 12, 'bold'), text_color='#00ff00'),
                         sg.Text("{}".format(cs[3]), font=('Any', 12), enable_events=True, key='zoomUrl',
                                 text_color='#0000ff'), sg.Open()],
                        [sg.Text("Class room:", size=(20, 2), font=('Any', 12, 'bold'), text_color='#00ff00'),
                         sg.Text("{}".format(cs[4]), size=(40, 2), font=('Any', 12))],
                        [sg.Text("Starting time:", size=(20, 2), font=('Any', 12, 'bold'), text_color='#00ff00'),
                         sg.Text("{}".format(cs[5]), size=(40, 2), font=('Any', 12))],
                        [sg.Text("Lecture/Tutorial notes:", size=(20, 2), font=('Any', 12, 'bold'), text_color='#00ff00'),
                         sg.Text("{}".format(cs[6]), font=('Any', 12), enable_events=True, key='link',
                                 text_color='#0000ff'), sg.Open('open')],
                        [sg.Exit()]]
                    win = sg.Window('You have a class approaching, Showing Details', layout)
                    while 1:
                        event, values = win.Read()
                        if event == 'Open':
                            webbrowser.open(cs[3])
                        elif (event == 'open'):
                            webbrowser.open(cs[6])
                        else:
                            break


                update = "INSERT INTO login_history values(%s,%s)"
                val = (data[0], date)
                cursor.execute(update, val)

#@ end 1

                update = "UPDATE Student SET login_date=%s WHERE name=%s"
                val = (date, current_name)
                cursor.execute(update, val)
                update = "UPDATE Student SET login_time=%s WHERE name=%s"
                val = (current_time, current_name)
                cursor.execute(update, val)
                myconn.commit()

                hello = ("Hello ", current_name, "You did attendance today")
                print(hello)
                engine.say(hello)

#@ start 2
                # exhibit hello window
                sg.theme(theme_name_list[data[0]])
                layout = [
                    [sg.Text("Hello {}!".format(current_name), size=(40, 4), font=('Any', 18))],
                    [sg.Text("Login at {}".format(current_time), size=(40, 4), font=('Any', 18))],
                    [sg.OK()]
                ]
                win = sg.Window("Hello window", layout)
                event, values = win.Read()
                if event == 'Exit' or event == sg.WIN_CLOSED:
                    break
                else:
                    # if has lecture within one hour
                    sqlcomm = "select c.course_name, lecture.lecturer_msg, lecture.lecturer_name, lecture.lecture_zoomlink, lecture.lecture_address, lecture.lecture_start_time, lecture_material_link from course as c, lecture as lecture where c.course_id = lecture.course_id and c.year_semester = lecture.year_semester and (c.course_id, c.year_semester) in ( select course_id, year_semester from student_course_relationship where uid={}) and curdate()=lecture.lecture_date and lecture.lecture_start_time>curtime() and timediff(lecture.lecture_start_time,curtime())<'01:00:00'".format(data[0])
                    cursor.execute(sqlcomm)
                    results = cursor.fetchall()
                    hurryCourse = None
                    for x in results:
                        hurryCourse = x

                    if hurryCourse:
                        show_course_details(hurryCourse)
                        '''
                        layout_course_soon = [
                            [sg.Text("I will be the course soon")],
                            [sg.Text(str(hurryCourse))]
                            ]
                        win = sg.Window("courses", layout_course_soon)
                        event, values = win.Read()
                        '''
                    else:
                        # if has tutorial in one hour
                        sqlcomm = "select c.course_name, tutorial.tutor_msg, tutorial.tutor_name, tutorial.tutorial_zoomlink, tutorial.tutorial_address, tutorial.tutorial_start_time, tutorial_material_link from course as c, tutorial as tutorial where c.course_id = tutorial.course_id and c.year_semester = tutorial.year_semester and (c.course_id, c.year_semester) in ( select course_id, year_semester from student_course_relationship where uid={}) and curdate()=tutorial.tutorial_date and tutorial.tutorial_start_time>curtime() and timediff(tutorial.tutorial_start_time,curtime())<'01:00:00'".format(data[0])
                        cursor.execute(sqlcomm)
                        tutorial_results = cursor.fetchall()
                        for x in tutorial_results:
                            hurryCourse = x
                        
                        if hurryCourse:
                            show_course_details(hurryCourse)
                            '''
                            layout_course_soon = [
                                [sg.Text("I will be the course soon")],
                                [sg.Text(str(hurryCourse))]
                                ]
                            win = sg.Window("courses", layout_course_soon)
                            event, values = win.Read()
                            '''
                        
                        else:
                            #no tutorial and no lecture, display timetable
                            sqlcomm = "select c.course_name, lecture.lecture_id, lecture.lecturer_name, lecture.lecture_date, lecture.lecture_zoomlink, lecture.lecture_address, lecture.lecture_start_time, lecture_material_link from course as c, lecture as lecture where c.course_id = lecture.course_id and c.year_semester = lecture.year_semester and (c.course_id, c.year_semester) in ( select course_id, year_semester from student_course_relationship where uid={})".format(data[0])
                            cursor.execute(sqlcomm)
                            result = cursor.fetchall()
                            showCourses(result)
                            
                            sqlcomm = "select c.course_name, tutorial.tutorial_id, tutorial.tutor_name, tutorial.tutorial_date, tutorial.tutorial_zoomlink, tutorial.tutorial_address, tutorial.tutorial_start_time, tutorial_material_link from course as c, tutorial as tutorial where c.course_id = tutorial.course_id and c.year_semester = tutorial.year_semester and (c.course_id, c.year_semester) in ( select course_id, year_semester from student_course_relationship where uid={})".format(data[0])
                            cursor.execute(sqlcomm)
                            result = cursor.fetchall()
                            showCourses(result)
                # else
                exit()

#@ end 2

        # If the face is unrecognized
        else:
            color = (255, 0, 0)
            stroke = 2
            font = cv2.QT_FONT_NORMAL
            cv2.putText(frame, "UNKNOWN", (x, y), font, 1, color, stroke, cv2.LINE_AA)
            cv2.rectangle(frame, (x, y), (x + w, y + h), (255, 0, 0), (2))
            hello = ("Your face is not recognized")
            print(hello)
            engine.say(hello)
            # engine.runAndWait()

    # GUI
    imgbytes = cv2.imencode('.png', frame)[1].tobytes()
    if not win_started:
        win_started = True
        sg.theme(theme_name_list[data[0]])
        layout = [
            [sg.Text('Attendance System Interface', size=(30, 1))],
            [sg.Image(data=imgbytes, key='_IMAGE_')],
            [sg.Text('Confidence'),
             sg.Slider(range=(0, 100), orientation='h', resolution=1, default_value=gui_confidence, size=(15, 15),
                       key='confidence')],
            [sg.Text('Your confidence level is too high', size=(30,1))],
            [sg.Text('Try lowering to log in',size=(30,1))],
            [sg.Exit()]
        ]
        win = sg.Window('Attendance System',
                        default_element_size=(14, 1),
                        text_justification='right',
                        auto_size_text=False).Layout(layout).Finalize()
        image_elem = win.FindElement('_IMAGE_')
    else:
        image_elem.Update(data=imgbytes)

    event, values = win.Read(timeout=20)
    if event is None or event == 'Exit':
        break
    gui_confidence = values['confidence']

win.Close()
cap.release()
