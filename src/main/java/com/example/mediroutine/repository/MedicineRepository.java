package com.example.mediroutine.repository;

import com.example.mediroutine.entity.Medicine;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MedicineRepository extends JpaRepository<Medicine, Long> {

    List<Medicine> findByUserId(Long userId);
}
