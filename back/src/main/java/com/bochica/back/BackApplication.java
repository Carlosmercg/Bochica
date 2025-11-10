package com.bochica.back;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = "com.bochica")
public class BackApplication {
  public static void main(String[] args) {
    SpringApplication.run(BackApplication.class, args);
  }
}
