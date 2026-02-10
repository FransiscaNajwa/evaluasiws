-- MySQL Schema for evaluasiws database
-- Run this in phpMyAdmin or MySQL CLI

CREATE DATABASE IF NOT EXISTS evaluasiws;
USE evaluasiws;

CREATE TABLE IF NOT EXISTS target_data (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pelayaran VARCHAR(50) NOT NULL,
  kodeWS VARCHAR(20) NOT NULL,
  periode VARCHAR(20) NOT NULL,
  waktuBerthing VARCHAR(30) NOT NULL,
  waktuDeparture VARCHAR(30) NOT NULL,
  berthingTime VARCHAR(20) NOT NULL,
  targetBongkar INT NOT NULL,
  targetMuat INT NOT NULL,
  createdAt VARCHAR(30) NOT NULL,
  INDEX idx_periode (periode),
  INDEX idx_pelayaran (pelayaran)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS realisasi_data (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pelayaran VARCHAR(50) NOT NULL,
  kodeWS VARCHAR(20) NOT NULL,
  namaKapal VARCHAR(100) NOT NULL,
  periode VARCHAR(20) NOT NULL,
  waktuArrival VARCHAR(30) NOT NULL,
  waktuBerthing VARCHAR(30) NOT NULL,
  waktuDeparture VARCHAR(30) NOT NULL,
  berthingTime VARCHAR(20) NOT NULL,
  realisasiBongkar INT NOT NULL,
  realisasiMuat INT NOT NULL,
  createdAt VARCHAR(30) NOT NULL,
  INDEX idx_periode (periode),
  INDEX idx_pelayaran (pelayaran),
  INDEX idx_kapal (namaKapal)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
