package com.example.mediroutine.repository;

import com.example.mediroutine.entity.MedicineSchedule;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MedicineScheduleRepository extends JpaRepository<MedicineSchedule, Long> {

    List<MedicineSchedule> findByMedicineId(Long medicineId);
}
