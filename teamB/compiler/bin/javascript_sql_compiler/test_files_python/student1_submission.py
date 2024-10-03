# This is a comment. Python will ignore this line.

# Importing a module
import random

# Main program
if __name__ == "__main__":
    # Variables
    name = "Alice"
    age = 30
    
    # Using the function
    greeting = greet(name)
    print(greeting)
    
    # Conditional statement
    if age >= 18:
        print(f"{name} is an adult.")
    else:
        print(f"{name} is a minor.")
    
    # List and loop
    fruits = ["apple", "banana", "cherry"]
    print("I like these fruits:")
    for fruit in fruits:
        print(f"- {fruit}")
    
    # Using the random module
    random_number = random.randint(1, 10)
    print(f"Here's a random number between 1 and 10: {random_number}")
    
    # Basic input and output
    user_input = input("Enter your favorite color: ")
    print(f"Your favorite color is {user_input}!")
