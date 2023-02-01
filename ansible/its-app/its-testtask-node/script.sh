#!/bin/sh
echo "CONTENTFUL_SPACE_ID=$CONTENTFUL_SPACE_ID" >> /app/variables.env
echo "CONTENTFUL_DELIVERY_TOKEN=$CONTENTFUL_DELIVERY_TOKEN" >> /app/variables.env
echo "CONTENTFUL_PREVIEW_TOKEN=$CONTENTFUL_PREVIEW_TOKEN" >> /app/variables.env
npm run start:dev
/bin/sh
