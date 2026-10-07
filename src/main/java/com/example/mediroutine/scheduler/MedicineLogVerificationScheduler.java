package com.example.mediroutine.scheduler;

import com.example.mediroutine.service.MedicineLogService;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
public class MedicineLogVerificationScheduler {

    private final MedicineLogService medicineLogService;

    public MedicineLogVerificationScheduler(
            MedicineLogService medicineLogService
    ) {
        this.medicineLogService = medicineLogService;
    }

    // TESTING: runs every 2 minutes
    @Scheduled(fixedRate = 60000)
    public void verifyMedicineLogs() {

        LocalDate today = LocalDate.now();

        System.out.println(
                "Medicine Log Verification Scheduler running for: "
                        + today
        );

        medicineLogService.verifyLogsForDate(today);

        //check for missed medicines
        medicineLogService.markMissedLogs(today);
    }
}