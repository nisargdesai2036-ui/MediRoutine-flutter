package com.example.mediroutine.scheduler;

import com.example.mediroutine.service.MedicineLogService;
import org.springframework.boot.autoconfigure.web.WebProperties;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
public class MedicineLogGenerationScheduler {

    private final MedicineLogService medicineLogService;

    public MedicineLogGenerationScheduler(
            MedicineLogService medicineLogService
    ) {
        this.medicineLogService = medicineLogService;
    }

    /**
     * Runs every day at 12:05 AM.
     */
    @Scheduled(
            cron = "0 5 0 * * *",
            zone = "Asia/Kolkata"
    )
    public void generateDailyLogs() {

        LocalDate today =
                LocalDate.now();

        medicineLogService
                .generateLogsForDate(today);
    }
}