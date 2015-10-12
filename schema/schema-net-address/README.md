# basex-json-validation

Is Relax-NG suitable for JSON validation?

Short answer: yes, it's even better than JSON Schema.

## Running server

    gradlew httpstart

## Example JSON

    {
      "address": {
        "streetAddress": "21 2nd Street",
        "city": "New York"
      },
      "phoneNumber": [
        {
          "location": "home",
          "code": 44
        }
      ]
    }

## Example JSON Schema

    {
      "$schema": "http://json-schema.org/draft-04/schema#",
      "id": "http://jsonschema.net",
      "type": "object",
      "properties": {
        "address": {
          "id": "http://jsonschema.net/address",
          "type": "object",
          "properties": {
            "streetAddress": {
              "id": "http://jsonschema.net/address/streetAddress",
              "type": "string"
            },
            "city": {
              "id": "http://jsonschema.net/address/city",
              "type": "string"
            }
          },
          "required": [
            "streetAddress",
            "city"
          ]
        },
        "phoneNumber": {
          "id": "http://jsonschema.net/phoneNumber",
          "type": "array",
          "items": {
            "id": "http://jsonschema.net/phoneNumber/0",
            "type": "object",
            "properties": {
              "location": {
                "id": "http://jsonschema.net/phoneNumber/0/location",
                "type": "string"
              },
              "code": {
                "id": "http://jsonschema.net/phoneNumber/0/code",
                "type": "integer"
              }
            }
          }
        }
      },
      "required": [
        "address",
        "phoneNumber"
      ]
    }

## Example Relax NG (compact)

    start = element json { 
        isa-object
        & address
        & phonenumbers
    }

    address = element address {
        isa-object
        & street-address
        & city
    }

    phonenumbers = element phoneNumber {
        isa-array
        & element _ { phonenumber }*
    }

    phonenumber =
        isa-object
        & location
        & code

    location = element location { text }

    code = element code {
        isa-number
        & text
    }

    street-address = element streetAddress { text }
    city = element city { text }

    isa-object = attribute type { "object" }
    isa-array = attribute type { "array" }
    isa-number = attribute type { "number" }

## TODO

Use some schema examples from JSON Schema sites and show the same validation done via XML and it's schema technologies.

## JSON and validation links

http://jsonschema.net/#/

