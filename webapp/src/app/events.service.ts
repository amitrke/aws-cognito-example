import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class EventsService {

  apiUrl = 'https://api.subnext.com/events';

  constructor(
    private http: HttpClient
  ) { }

  saveEvent(event: Event, apiToken: string) {
    return this.http.post(this.apiUrl, event, {
      headers: {
        Authorization: `Bearer ${apiToken}`
      }
    });
  }

  getEvents(apiToken: string) {
    return this.http.get(this.apiUrl, {
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