import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface RiskAssessment {
    id?: string;
    status: 'STARTED' | 'COMPLETED';
    data?: string;
    mobileNumber?: string;
    createdAt?: string;
}

@Injectable({
    providedIn: 'root'
})
export class RiskAssessmentService {
    private apiUrl = '/api/risk-assessment';

    constructor(private http: HttpClient) { }

    createAssessment(assessment: Partial<RiskAssessment>): Observable<RiskAssessment> {
        return this.http.post<RiskAssessment>(this.apiUrl, assessment);
    }

    updateAssessment(id: string, assessment: Partial<RiskAssessment>): Observable<RiskAssessment> {
        return this.http.put<RiskAssessment>(`${this.apiUrl}/${id}`, assessment);
    }

    getAllAssessments(): Observable<RiskAssessment[]> {
        return this.http.get<RiskAssessment[]>(this.apiUrl);
    }

    getAssessmentsByMobile(mobile: string): Observable<RiskAssessment[]> {
        return this.http.get<RiskAssessment[]>(`${this.apiUrl}/user/${mobile}`);
    }

    getAssessmentById(id: string): Observable<RiskAssessment> {
        return this.http.get<RiskAssessment>(`${this.apiUrl}/${id}`);
    }
}
