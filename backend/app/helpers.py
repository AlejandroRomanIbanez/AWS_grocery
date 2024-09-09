from bson import ObjectId
from typing import Any, Dict


def serialize_object_id(obj: Any) -> Any:
    """
    Serializes ObjectId instances within a given object to strings.

    Args:
        obj (Any): The object to serialize.

    Returns:
        Any: The serialized object.
    """
    if isinstance(obj, ObjectId):
        return str(obj)
    elif isinstance(obj, dict):
        return {k: serialize_object_id(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [serialize_object_id(i) for i in obj]
    return obj


def to_dict(model: Any) -> Dict:
    """
    Converts a model instance to a dictionary if it has a dict() method.

    Args:
        model (Any): The model instance to convert.

    Returns:
        Dict: The dictionary representation of the model.

    Raises:
        ValueError: If the provided object does not have a dict() method.
    """
    if hasattr(model, 'dict'):
        return model.dict()
    raise ValueError("Provided object does not have a dict() method.")


def format_validation_error(validation_error):
    """
    Format Pydantic validation errors into user-friendly messages.

    Args:
        validation_error (ValidationError): The validation error from Pydantic.

    Returns:
        str: A formatted error message.
    """
    error_messages = []
    for error in validation_error.errors():
        field = error.get('loc', [''])[0]  # Get the field name
        error_type = error.get('type')  # Get the error type

        # Custom messages based on error type
        if error_type == "value_error.missing":
            msg = f"The field '{field}' cannot be empty."
        elif error_type == "type_error":
            expected_type = error.get('ctx', {}).get('expected_type', 'correct type')
            msg = f"The field '{field}' has an invalid type. Please provide a valid {expected_type}."
        elif error_type == "value_error.number.not_ge":
            limit_value = error.get('ctx', {}).get('limit_value', 'minimum value')
            msg = f"The field '{field}' should be greater than or equal to {limit_value}."
        else:
            msg = f"Invalid input for the field '{field}'. Please check your input."

        error_messages.append(msg)

    return " ".join(error_messages)
