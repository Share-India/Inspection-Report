import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface Rfq {
    id?: string;
    mobileNumber?: string;
    companyName: string;
    product: string;
    status?: 'PENDING' | 'QUOTED';
    rfqData: string; // JSON string
    quoteDetails?: string;
    quoteFilePath?: string;
    createdAt?: string;
}

@Injectable({
    providedIn: 'root'
})
export class RfqService {
    private apiUrl = '/api/rfq';

    constructor(private http: HttpClient) { }

    submitRfq(rfq: Rfq): Observable<Rfq> {
        return this.http.post<Rfq>(this.apiUrl, rfq);
    }

    getAllRfqs(): Observable<Rfq[]> {
        return this.http.get<Rfq[]>(this.apiUrl);
    }

    getUserRfqs(mobile: string): Observable<Rfq[]> {
        return this.http.get<Rfq[]>(`${this.apiUrl}/user/${mobile}`);
    }

    updateQuote(id: string, quoteDetails: string, file?: File): Observable<any> {
        const formData = new FormData();
        formData.append('quoteDetails', quoteDetails);
        formData.append('status', 'QUOTED');
        if (file) {
            formData.append('file', file);
        }
        return this.http.put(`${this.apiUrl}/${id}/quote`, formData);
    }
}
