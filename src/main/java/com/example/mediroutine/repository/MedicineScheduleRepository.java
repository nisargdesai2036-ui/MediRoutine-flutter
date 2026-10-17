package com.example.mediroutine.repository;

import com.example.mediroutine.entity.MedicineSchedule;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

public interface MedicineScheduleRepository
        extends JpaRepository<MedicineSchedule, Long> {

    List<MedicineSchedule> findByMedicineUserId(Long userId);

    Optional<MedicineSchedule> findByIdAndMedicineId(
            Long scheduleId,
            Long medicineId
    );

    List<MedicineSchedule> findByMedicineId(
            Long medicineId
    );

//
//    startDate <= today AND endDate >= today
    List<MedicineSchedule> findByStartDateLessThanEqualAndEndDateGreaterThanEqual(LocalDate date1, LocalDate date2);

    List<MedicineSchedule> findByStartDateLessThanEqualAndEndDateIsNull(LocalDate date1);
}