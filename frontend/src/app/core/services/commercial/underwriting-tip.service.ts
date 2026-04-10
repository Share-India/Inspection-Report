import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface UnderwritingTip {
    id?: string;
    title: string;
    category: string;
    description: string;
    example: string;
    keyTakeaway: string;
    imagePath?: string;
    createdAt?: string;
}

@Injectable({
    providedIn: 'root'
})
export class UnderwritingTipService {
    private apiUrl = '/api/underwriting/tips';

    constructor(private http: HttpClient) { }

    createTip(tip: UnderwritingTip, image?: File): Observable<UnderwritingTip> {
        const formData = new FormData();
        formData.append('tipData', JSON.stringify(tip));
        if (image) {
            formData.append('image', image);
        }
        return this.http.post<UnderwritingTip>(this.apiUrl, formData);
    }

    getAllTips(): Observable<UnderwritingTip[]> {
        return this.http.get<UnderwritingTip[]>(this.apiUrl);
    }

    getTipById(id: string): Observable<UnderwritingTip> {
        return this.http.get<UnderwritingTip>(`${this.apiUrl}/${id}`);
    }

    deleteTip(id: string): Observable<void> {
        return this.http.delete<void>(`${this.apiUrl}/${id}`);
    }
}
