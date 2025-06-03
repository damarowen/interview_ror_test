
````markdown
# Live on 

https://rubyonrails.damarowen.blog/

# 📦 Interview Test API


Sebuah project Ruby on Rails untuk take-home test. Fitur meliputi:

- ✅ Unit test dengan RSpec
- 🧠 Caching (optional)
- 📚 Dokumentasi kode dengan YARD
- 📊 Laporan coverage test

---

## 🚀 Goals

1. Implementasi unit test dengan cakupan yang memadai
2. Menjalankan semua test menggunakan `rspec`
3. (Optional) Menambahkan mekanisme caching
4. Dokumentasi internal API/controller/service menggunakan YARD
5. Menyediakan laporan coverage test

---

## 🛠️ Setup Project

### 1. Clone & Install dependencies

```bash
git clone https://github.com/username/interview-test-api.git
cd interview-test-api
bundle install
````

### 2. Setup Database

```bash
rails db:create db:migrate
```

### 3. Jalankan Server

```bash
rails server
```

Akses di browser:

```
http://localhost:3000
```

---

## ✅ Testing

### Menjalankan RSpec

```bash
bundle exec rspec
```

---

## 📊 Test Coverage Report

Jika kamu menggunakan `simplecov`, laporan akan tersedia setelah RSpec dijalankan.

### Akses laporan coverage:

```
http://127.0.0.1:3000/coverage/index.html#_AllFiles
```

> File ini biasanya berada di folder `coverage/` hasil dari SimpleCov.

---

## 📚 Dokumentasi YARD

### 1. Generate dokumentasi:

```bash
yard doc --output-dir public/doc
```

### 2. Akses dokumentasi:

```
http://127.0.0.1:3000/doc/index.html
```

# 📌 API Endpoints

## Users
- `GET    /api/v1/users`  
  ↳ **Query Params**:  
  &nbsp;&nbsp;&nbsp;&nbsp;`page` – halaman (opsional)  
  &nbsp;&nbsp;&nbsp;&nbsp;`per_page` – jumlah per halaman (opsional)

- `GET    /api/v1/users/:id`
- `POST   /api/v1/users`
- `PATCH  /api/v1/users/:id`
- `PUT    /api/v1/users/:id`
- `DELETE /api/v1/users/:id`

---

## Jobs
- `GET    /api/v1/jobs`  
  ↳ **Query Params**:  
  &nbsp;&nbsp;&nbsp;&nbsp;`user_id` – filter berdasarkan ID user (opsional)  
  &nbsp;&nbsp;&nbsp;&nbsp;`page` – halaman (opsional)  
  &nbsp;&nbsp;&nbsp;&nbsp;`per_page` – jumlah per halaman (opsional)

- `GET    /api/v1/jobs/:id`
- `POST   /api/v1/jobs`
- `PATCH  /api/v1/jobs/:id`
- `PUT    /api/v1/jobs/:id`
- `DELETE /api/v1/jobs/:id`


---

## 🔧 Tools

* Rails 7.x / 6.x
* Ruby 3.x
* RSpec
* SimpleCov
* ActiveModelSerializers
* YARD

---

