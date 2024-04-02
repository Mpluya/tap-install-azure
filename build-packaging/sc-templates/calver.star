load("@ytt:python_lib/time", "time")

def get_current_datetime():
    current_time = time.now()
    return str(current_time)
end