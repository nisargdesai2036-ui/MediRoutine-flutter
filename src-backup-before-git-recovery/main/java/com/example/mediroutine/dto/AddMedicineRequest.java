package com.example.mediroutine.dto;

public class AddMedicineRequest {

    private MedicineRequest medicine;
    private MedicineScheduleRequest schedule;

    public MedicineRequest getMedicine() {
        return medicine;
    }

    public void setMedicine(MedicineRequest medicine) {
        this.medicine = medicine;
    }

    public MedicineScheduleRequest getSchedule() {
        return schedule;
    }

    public void setSchedule(MedicineScheduleRequest schedule) {
        this.schedule = schedule;
    }
}
