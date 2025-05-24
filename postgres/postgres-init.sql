CREATE TABLE clientes (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100),
  email VARCHAR(100),
  fecha_creacion TIMESTAMP DEFAULT now()
);