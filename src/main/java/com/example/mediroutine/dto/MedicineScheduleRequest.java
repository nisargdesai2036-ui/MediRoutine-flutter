package com.example.mediroutine.dto;

import com.example.mediroutine.entity.FrequencyType;
import com.example.mediroutine.entity.Period;

import java.time.LocalDate;
import java.time.LocalTime;

public class MedicineScheduleRequest {

    private Long medicineId;
    private String dosage;
    private Integer quantity;
    private String unit;
    private LocalTime time;
    private Period period;
    private FrequencyType frequencyType;
    private Integer intervalDays;
    private String daysOfWeek;
    private LocalDate startDate;
    private LocalDate endDate;

    public MedicineScheduleRequest() {
    }

    public MedicineScheduleRequest(Long medicineId, String dosage, Integer quantity, String unit, LocalTime time,
                                   Period period, FrequencyType frequencyType, Integer intervalDays,
                                   String daysOfWeek, LocalDate startDate, LocalDate endDate) {
        this.medicineId = medicineId;
        this.dosage = dosage;
        this.quantity = quantity;
        this.unit = unit;
        this.time = time;
        this.period = period;
        this.frequencyType = frequencyType;
        this.intervalDays = intervalDays;
        this.daysOfWeek = daysOfWeek;
        this.startDate = startDate;
        this.endDate = endDate;
    }

    public Long getMedicineId() {
        return medicineId;
    }

    public void setMedicineId(Long medicineId) {
        this.medicineId = medicineId;
    }

    public String getDosage() {
        return dosage;
    }

    public void setDosage(String dosage) {
        this.dosage = dosage;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public LocalTime getTime() {
        return time;
    }

    public void setTime(LocalTime time) {
        this.time = time;
    }

    public Period getPeriod() {
        return period;
    }

    public void setPeriod(Period period) {
        this.period = period;
    }

    public FrequencyType getFrequencyType() {
        return frequencyType;
    }

    public void setFrequencyType(FrequencyType frequencyType) {
        this.frequencyType = frequencyType;
    }

    public Integer getIntervalDays() {
        return intervalDays;
    }

    public void setIntervalDays(Integer intervalDays) {
        this.intervalDays = intervalDays;
    }

    public String getDaysOfWeek() {
        return daysOfWeek;
    }

    public void setDaysOfWeek(String daysOfWeek) {
        this.daysOfWeek = daysOfWeek;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }
}
