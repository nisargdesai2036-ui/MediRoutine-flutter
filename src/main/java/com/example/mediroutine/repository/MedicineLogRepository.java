package com.example.mediroutine.repository;

import com.example.mediroutine.entity.MedicineLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MedicineLogRepository extends JpaRepository<MedicineLog, Long> {

    List<MedicineLog> findByScheduleId(Long scheduleId);
}
