load("@std//time:time.bzl", "now")

def get_current_date():
    return now().format("%Y-%m-%d")
end