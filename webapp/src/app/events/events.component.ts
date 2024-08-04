import { Component } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { Event, EventsService } from '../events.service';
import { AuthService } from '../auth.service';

@Component({
  selector: 'app-events',
  templateUrl: './events.component.html',
  styleUrl: './events.component.scss'
})
export class EventsComponent {

  //Time list with 30 minute intervals from 6:00 AM to 11:30 PM
  timeList = [
    '6:00 AM', '6:30 AM', '7:00 AM', '7:30 AM', '8:00 AM', '8:30 AM', '9:00 AM', '9:30 AM',
    '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM', '1:00 PM', '1:30 PM',
    '2:00 PM', '2:30 PM', '3:00 PM', '3:30 PM', '4:00 PM', '4:30 PM', '5:00 PM', '5:30 PM',
    '6:00 PM', '6:30 PM', '7:00 PM', '7:30 PM', '8:00 PM', '8:30 PM', '9:00 PM', '9:30 PM',
    '10:00 PM', '10:30 PM', '11:00 PM', '11:30 PM'
  ];

  //Event form
  eventForm = new FormGroup({
    name: new FormControl('', Validators.compose([Validators.required, Validators.minLength(3), Validators.maxLength(50)])),
    date: new FormControl('', Validators.compose([Validators.required, Validators.pattern(/^\d{4}-\d{2}-\d{2}$/)])),
    time: new FormControl('', Validators.compose([Validators.required, Validators.pattern(/^\d{2}:\d{2} (AM|PM)$/)])),
    location: new FormControl('', Validators.compose([Validators.required, Validators.minLength(3), Validators.maxLength(10)])),
    description: new FormControl('', Validators.compose([Validators.required, Validators.minLength(3), Validators.maxLength(100)])) 
  });

  private apiToken = '';

  events: Event[] = [];

  constructor(
    private eventsService: EventsService,
    private authService: AuthService
  ) { }

  async ngOnInit() {
    this.apiToken = (await this.authService.getIDToken()) || '';
    this.eventsService.getEvents(this.apiToken).subscribe(
      response => {
        this.events = this.transformGetResponse(response);
      },
      error => {
        console.error(error);
      }
    );
  }

  onSubmit() {
    const event = this.eventTransform();
    this.eventsService.saveEvent(event, this.apiToken).subscribe(
      response => {
        console.log(response);
      },
      error => {
        console.error(error);
      }
    );
    console.log(this.eventForm.value);
  }

  transformGetResponse(response: any): Event[] {
    const events: Event[] = [];
    for (let event of response) {
      events.push({
        name: event.data.name,
        date: event.data.date,
        time: event.data.time,
        location: event.data.location,
        description: event.data.description
      });
    }
    return events;
  }

  eventTransform(): Event {
    //OCBC#2024-08-03T07:00:00.000Z#6
    let parsedDate = new Date(this.eventForm.value.date || '');
    //Format date to YYYYMMDD
    let dateValue = parsedDate.toISOString();
    dateValue = dateValue.split('T')[0].replace(/-/g, '');
    let timeValue = this.eventForm.value.time || '';
    //Current format is 6:30 AM convert to 24 hour format
    let hour = parseInt(timeValue.split(':')[0]);
    let minute = parseInt(timeValue.split(':')[1].split(' ')[0]);
    let ampm = timeValue.split(' ')[1];
    if (ampm === 'PM') {
      hour += 12;
    }
    timeValue = hour + ':' + minute;

    return {
      name: this.eventForm.value.name || '',
      date: dateValue,
      time: timeValue,
      location: this.eventForm.value.location || '',
      description: this.eventForm.value.description || ''
    };
  }

}
