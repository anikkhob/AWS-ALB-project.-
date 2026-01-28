# 🚀 AWS Application Load Balancer (ALB)


<img width="1980" height="2283" alt="image" src="https://github.com/user-attachments/assets/186a5505-b76b-4f64-b1a9-fa86b24abf47" />

## 📌 Overview
An **Application Load Balancer (ALB)** is a Layer 7 (HTTP/HTTPS) load balancer provided by AWS.  
It intelligently distributes incoming application traffic across multiple targets such as **EC2 instances, containers (ECS/EKS), and IP addresses**.

ALB is best suited for **web applications, microservices, and APIs** where routing decisions are based on request content.

---

## 🎯 Key Features
- ✅ Layer 7 load balancing (HTTP / HTTPS)
- ✅ Path-based & host-based routing
- ✅ Native integration with AWS services
- ✅ SSL/TLS termination
- ✅ Health checks for targets
- ✅ Auto-scaling friendly
- ✅ High availability across multiple AZs

---

## 🧩 ALB Components

### 1️⃣ Listener
- Listens on a specific **port and protocol** (e.g., HTTP:80, HTTPS:443)
- Applies **rules** to forward traffic

### 2️⃣ Listener Rules
- Route traffic based on:
  - URL path (`/api`, `/login`)
  - Host headers (`app.example.com`)
  - HTTP headers

### 3️⃣ Target Group
- Logical group of backend resources
- Can include:
  - EC2 instances
  - IP addresses
  - Containers (ECS / EKS)
- Performs **health checks**

### 4️⃣ Targets
- Actual backend servers that handle requests

---

## 🔄 ALB Workflow (How It Works)

```text
Client Request
      |
      v
DNS (Route 53 / Public URL)
      |
      v
Application Load Balancer
      |
      v
Listener (80 / 443)
      |
      v
Listener Rules
      |
      v
Target Group
      |
      v
Healthy Targets (EC2 / Pods / Containers)


## 🌐 VPC Architecture & Private Subnet Traffic

This project is deployed inside a **custom AWS VPC** to ensure secure and isolated networking.

### 🧱 Network Design
- **VPC**: Custom CIDR range
- **Public Subnet**:
  - Application Load Balancer (ALB)
  - Internet Gateway attached
- **Private Subnet**:
  - EC2 instances running Apache2
  - No direct internet access

### 🔄 Traffic Flow
```text
User (Internet)
     |
     v
Application Load Balancer (Public Subnet)
     |
     v
Target Group
     |
     v
EC2 Instance (Private Subnet)
     |
     v
Apache2 Web Server




---

If you want, next I can:
- 📌 Add **user-data script** for Apache2
- 📌 Add **Auto Scaling Group**
- 📌 Convert this into **interview-ready explanation**
- 📌 Make a **diagram section for GitHub**

Just say the word 🚀



---

If you want, I can also:
- 🔹 Add **diagrams (ASCII or draw.io style)**
- 🔹 Convert this into **GitHub professional format**
- 🔹 Add **ALB + EC2 + Auto Scaling example**
- 🔹 Simplify it for **interview explanation**

Just tell me 😄


