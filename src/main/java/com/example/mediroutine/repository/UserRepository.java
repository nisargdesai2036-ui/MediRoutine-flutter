package com.example.mediroutine.repository;

import com.example.mediroutine.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

     //It is project specfic method so we need to declare it , implementation is handle by the JPA itself.
     Optional<User> findByEmail(String email);
}
