# Hunter Qualifier

API service for qualifying users based on email and additional metadata.

## Setup

### Prerequisites

- Ruby 3.4.4
- Bundler

### Installation

1. Clone the repository:
```bash
git clone git@github.com:jromainkrupa/hunter_qualifier.git
cd hunter_qualifier
```

2. Check Ruby version:
```bash
ruby -v
# Should output: ruby 3.4.4
```

3. Install dependencies:
```bash
bundle install
```

4. Configure the API token:
I only included the keys in the development credentials.
The key has been given to you via email. so you can
SO in theory you just need to create a file
```bash
touch config/credentials/development.key
```
and paste the key in it.

5. Start the Rails server:
```bash
rails server
```

The API will be available at `http://localhost:3000`

## API Usage

### Authentication

All API requests require a Bearer token. You should receive your API token via email.

### Endpoint

**POST** `/api/v1/qualifications`

### Example Request

```bash
curl -X POST "http://localhost:3000/api/v1/qualifications" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{
    "qualification": {
      "email": "marc.benioff@salesforce.com"
    }
  }'
```

### Request Parameters

The `qualification` object accepts the following optional parameters:
- `email` (required)
- `first_name`
- `last_name`
- `password`
- `signup_source`
- `location`
- `ip_address`

### Example with Additional Parameters

```bash
curl -X POST "http://localhost:3000/api/v1/qualifications" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{
    "qualification": {
      "email": "bastien@hunter.io",
      "location": "nigeria",
      "signup_source": "appsumo"
    }
  }'
```

Replace `YOUR_API_TOKEN` with the API token you received via email.


## Improvements
- Do the work in the background
- If generic email like sales, support. Could we bucket them in a different bucket?
- The location is a bit misleading as is the prompt as to be improved.
