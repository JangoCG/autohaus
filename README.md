# Auftragsheld

Rails 8.1 Anwendung mit Double-Opt-In Waitlist.

## Setup

```bash
bin/setup
bin/dev
```

## Tests

```bash
bin/rails test
```

## Deployment

```bash
kamal deploy
```

### Admin-User erstellen

```bash
kamal console
```

Dann in der Rails Console:

```ruby
User.create!(email_address: "cengiz.guertusgil@gmail.com", password: "Babaadmin123@", admin: true)
```

### Datenbank zurücksetzen (Production)

```bash
kamal app exec -i "sh -c 'DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bin/rails db:drop db:create db:migrate'"
```

## Admin

Nach Login unter `/admin` erreichbar. Zeigt Waitlist-Statistiken.
