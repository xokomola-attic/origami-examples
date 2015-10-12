# Relax NG Schemas

## Schemas as data with code

Write the schema roughly in the shape of what you need and using functions to produce the schema structure (an Origami document that, when serialized to XML becomes an Relax NG schema).

## Schemas as RNC

Relax NG in compact syntax is a perfect way to create readable schemas. To use them you can convert them to XML and then convert them to an Origami Schema structure.

## Using validation

- In code
- In tests
- At an API endpoint (is this producing what we promised?)
- Only during development

## Generate examples

- For generative testing

## Data coercion

- Let the schema drive a transformation that can turn "10" into 10 and "true" or "yes" into true().
