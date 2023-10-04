import json
def get_nested_value(obj, key):
    keys = key.split('/')
    current = obj

    for k in keys:
        if isinstance(current, dict) and k in current:
            current = current[k]
        else:
            return None

    return current

object_input = input("Enter the object as a JSON string: ")
try:
    object_dict = json.loads(object_input)
except json.JSONDecodeError:
    print("Invalid JSON input")
    exit(1)

key_input = input("Enter the key: ")

result = get_nested_value(object_dict, key_input)

if result is not None:
    print(f"{result}")
else:
    print("None")