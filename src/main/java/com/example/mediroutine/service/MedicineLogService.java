package com.example.mediroutine.service;

import com.example.mediroutine.entity.FrequencyType;
import com.example.mediroutine.entity.MedicineLog;
import com.example.mediroutine.entity.MedicineSchedule;
import com.example.mediroutine.entity.LogStatus;
import com.example.mediroutine.repository.MedicineLogRepository;
import com.example.mediroutine.repository.MedicineScheduleRepository;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class MedicineLogService {

    private final MedicineLogRepository medicineLogRepository;
    private final MedicineScheduleRepository medicineScheduleRepository;

    public MedicineLogService(MedicineLogRepository medicineLogRepository,MedicineScheduleRepository medicineScheduleRepository) {
        this.medicineLogRepository = medicineLogRepository;
        this.medicineScheduleRepository = medicineScheduleRepository;
    }

    public List<MedicineLog> getAllLogs() {
        return medicineLogRepository.findAll();
    }

    public Optional<MedicineLog> getLogById(Long id) {
        return medicineLogRepository.findById(id);
    }

    public List<MedicineLog> getLogsByScheduleId(Long scheduleId) {
        return medicineLogRepository.findBySchedule_IdOrderByScheduledDateDescScheduleTimeDesc(scheduleId);
    }

    public MedicineLog saveLog(MedicineLog log) {
        return medicineLogRepository.save(log);
    }

    public void deleteLogById(Long id) {
        medicineLogRepository.deleteById(id);
    }


    // function definiation for creating the logs if not exists
    @Transactional
    public void createLogIdNotExsits(MedicineSchedule schedule,LocalDate DDate) {

       LocalTime scheduleTime = schedule.getTime();

        boolean alreadyExists =
                medicineLogRepository
                        .existsByScheduleDateAndTime(
                                schedule.getId(),
                                DDate,
                                scheduleTime
                        );

       if (alreadyExists) {
           return;
       }

           MedicineLog medicineLog = new MedicineLog();


            medicineLog.setSchedule(schedule);
            medicineLog.setScheduledDate(DDate);
            medicineLog.setScheduledTime(scheduleTime);
            medicineLog.setStatus(LogStatus.SCHEDULED);
            medicineLog.setActionTime(null);

            medicineLogRepository.save(medicineLog);


    }

    @Transactional
    public void generateLogsForDate(LocalDate date) {

        List<MedicineSchedule> schedules= medicineScheduleRepository.findByStartDateLessThanEqualAndEndDateGreaterThanEqual(date, date);

        List<MedicineSchedule> scheduleswithoutEndDates = medicineScheduleRepository.findByStartDateLessThanEqualAndEndDateIsNull(date);


        schedules.addAll(scheduleswithoutEndDates);


        for(MedicineSchedule schedule : schedules)
        {
            if(isSchdulefordate(schedule,date))
            {
                createLogIdNotExsits(schedule,date);
            }

        }
    }

    @Transactional
    public void verifyLogsForDate(LocalDate date) {

        // Get all schedules that should be active on this date
        List<MedicineSchedule> schedules =
                medicineScheduleRepository
                        .findByStartDateLessThanEqualAndEndDateGreaterThanEqual(
                                date,
                                date
                        );

        // Get schedules which have no end date
        List<MedicineSchedule> schedulesWithoutEndDates =
                medicineScheduleRepository
                        .findByStartDateLessThanEqualAndEndDateIsNull(
                                date
                        );

        schedules.addAll(schedulesWithoutEndDates);

        // Check every schedule
        for (MedicineSchedule schedule : schedules) {

            // Check whether this medicine should be taken today
            if (isSchdulefordate(schedule, date)) {

                // Create the log if Scheduler 1 missed it
                createLogIdNotExsits(schedule, date);
            }
        }
    }

    private boolean isSchdulefordate(MedicineSchedule schedule,LocalDate date) {

        FrequencyType frequencyType = schedule.getFrequencyType();

        if (frequencyType == null) {
            return false;
        }

        switch (frequencyType) {
            case DAILY:
                return true;

            case SPECIFIC_DAYS:
                return isSpecficDay(schedule, date);

            case EVERY_N_DAYS:
                return isEveryNDays(schedule, date);

            default:
                return false;
        }

    }


    private boolean isSpecficDay(MedicineSchedule schedule,LocalDate date)
    {
        String daysofWeek=schedule.getDaysOfWeek();

        if(daysofWeek==null || daysofWeek.isBlank())  return false;

        String today = convertDayToShortName(date.getDayOfWeek());

        String [] days = daysofWeek.toUpperCase().split(",");

        for(String day:days)
        {
            if(day.equals(today))
                return true;
        }
        return false;
    }


    private boolean isEveryNDays(MedicineSchedule schedule, LocalDate date)
    {
        Integer intervalDays = schedule.getIntervalDays();

        if(intervalDays==null || intervalDays<=0) return false;

        LocalDate startDate=schedule.getStartDate();

        long daysBetween=java.time.temporal.ChronoUnit.DAYS.between(startDate,date);
        return daysBetween % intervalDays ==0;
    }

    private String convertDayToShortName(DayOfWeek day)
    {
        switch (day) {

            case MONDAY:
                return "MON";

            case TUESDAY:
                return "TUE";

            case WEDNESDAY:
                return "WED";

            case THURSDAY:
                return "THU";

            case FRIDAY:
                return "FRI";

            case SATURDAY:
                return "SAT";

            case SUNDAY:
                return "SUN";

            default:
                return "";
        }

    }


    @Transactional
    public void markMissedLogs(LocalDate date) {

        LocalDateTime currentDateTime = LocalDateTime.now();

        List<MedicineLog> logs =
                medicineLogRepository.findByScheduledDateAndStatus(
                        date,
                        LogStatus.SCHEDULED
                );

        for (MedicineLog log : logs) {

            LocalDateTime scheduledDateTime =
                    LocalDateTime.of(
                            log.getScheduledDate(),
                            log.getScheduledTime()
                    );

            LocalDateTime missedAfter =
                    scheduledDateTime.plusMinutes(30);

            if (currentDateTime.isAfter(missedAfter)) {

                log.setStatus(LogStatus.MISSED);

                medicineLogRepository.save(log);
            }
        }
    }

    public List<MedicineLog> getLogsOfSchedule(Long scheduleId)
    {
        return medicineLogRepository.findBySchedule_IdOrderByScheduledDateDescScheduleTimeDesc(scheduleId);
    }
}
