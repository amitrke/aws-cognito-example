import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { AuthService } from './auth.service';

@Injectable({
  providedIn: 'root'
})
export class EventsService {

  apiUrl = 'https://api.subnext.com/events';

  constructor(
    private http: HttpClient
  ) { }

  saveEvent(event: Event, apiToken: string) {
    console.log('apiToken', apiToken);
    return this.http.post(this.apiUrl, event, {
      headers: {
        Authorization: `Bearer ${apiToken}`
      }
    });
  }

}

export type Event = {
  id?: number;
  name: string;
  date: string;
  time: string;
  location: string;
  description: string;
};