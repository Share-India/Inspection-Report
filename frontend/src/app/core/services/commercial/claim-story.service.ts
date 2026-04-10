import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface ClaimStory {
    id?: string;
    title: string;
    category?: string;
    caseName: string;
    court: string;
    issue: string;
    story: string;
    verdict: string;
    principles: string[];
    bottomLine: string;
    imagePath?: string;
    createdAt?: string;
}

@Injectable({
    providedIn: 'root'
})
export class ClaimStoryService {
    private apiUrl = '/api/claims/stories';

    constructor(private http: HttpClient) { }

    createStory(story: ClaimStory, image?: File): Observable<ClaimStory> {
        const formData = new FormData();
        formData.append('storyData', JSON.stringify(story));
        if (image) {
            formData.append('image', image);
        }
        return this.http.post<ClaimStory>(this.apiUrl, formData);
    }

    getAllStories(): Observable<ClaimStory[]> {
        return this.http.get<ClaimStory[]>(this.apiUrl);
    }

    getStoryById(id: string): Observable<ClaimStory> {
        return this.http.get<ClaimStory>(`${this.apiUrl}/${id}`);
    }

    deleteStory(id: string): Observable<void> {
        return this.http.delete<void>(`${this.apiUrl}/${id}`);
    }
}
