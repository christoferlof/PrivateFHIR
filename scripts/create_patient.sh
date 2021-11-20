#!/bin/bash

TOKEN=""
FHIR_HOST="https://.azurehealthcareapis.com"

PATIENT_ID=$(cat /proc/sys/kernel/random/uuid)
PATIENT=$(jq -c . << JSON
{
    "resourceType": "Patient",
    "identifier": [{
      "system": "local",
      "value": "${PATIENT_ID}"
    },
    {
      "system": "remote",
      "value": "R-${PATIENT_ID}"
    }],
    "name": [
        {
            "family": [
                "Brekke496"
            ]
        },
        {
            "given": [
                "Aaron697"
            ]
        }
    ]
}
JSON
)

curl --location --request POST "${FHIR_HOST}/Patient" \
        --header "Authorization: Bearer ${TOKEN}" \
        --header "Content-Type: Application/fhir+json" \
        --data-raw $PATIENT