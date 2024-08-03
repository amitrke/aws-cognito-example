import { Component } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { EventsService } from '../events.service';
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

  constructor(
    private eventsService: EventsService,
    private authService: AuthService
  ) { }

  async ngOnInit() {
    this.apiToken = (await this.authService.getIDToken()) || '';
  }

  onSubmit() {
    const event = {
      name: this.eventForm.value.name || '',
      date: this.eventForm.value.date || '',
      time: this.eventForm.value.time || '',
      location: this.eventForm.value.location || '',
      description: this.eventForm.value.description || ''
    };

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

}
