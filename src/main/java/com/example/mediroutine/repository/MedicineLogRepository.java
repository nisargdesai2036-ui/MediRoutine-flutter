package com.example.mediroutine.repository;

import com.example.mediroutine.entity.LogStatus;
import com.example.mediroutine.entity.MedicineLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

public interface MedicineLogRepository extends JpaRepository<MedicineLog, Long> {

    List<MedicineLog> findByScheduleId(Long scheduleId);
    List<MedicineLog> findBySchedule_IdOrderByScheduledDateDescScheduleTimeDesc(Long scheduleId);


    // If the log exist or not
    // if exist   -> return true  do not create another one
    // if dones exist -> return false  create the log

    //existsByScheduleIdAndScheduledDateAndScheduledTime
    @Query("""
        SELECT CASE WHEN COUNT(log) > 0 THEN true ELSE false END
        FROM MedicineLog log
        WHERE log.schedule.id = :scheduleId
        AND log.scheduledDate = :scheduledDate
        AND log.scheduledTime = :scheduledTime
    """)
    boolean existsByScheduleDateAndTime(
            @Param("scheduleId") Long scheduleId,
            @Param("scheduledDate") LocalDate scheduledDate,
            @Param("scheduledTime") LocalTime scheduledTime
    );

    List<MedicineLog> findByScheduledDateAndStatus(
            LocalDate scheduledDate,
            LogStatus status
    );

}
