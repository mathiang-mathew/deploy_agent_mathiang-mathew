#!/bin/bash
# Project factory for the attendance tracker
read -p "Enter a student name: " user_input
mkdir -p "attendance_tracker_${user_input}"
mkdir -p "attendance_tracker_${user_input}/Helpers"
mkdir -p "attendance_tracker_${user_input}/reports"
