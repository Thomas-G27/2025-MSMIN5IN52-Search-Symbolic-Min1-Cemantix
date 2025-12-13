import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { ApiService } from '../../services/api.service';
import { Debate } from '../../models';

@Component({
  selector: 'app-topics-list',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './topics-list.component.html',
  styleUrls: ['./topics-list.component.css']
})
export class TopicsListComponent implements OnInit {
  debates: Debate[] = [];
  
  // Gestion de la modale de configuration
  selectedDebate: Debate | null = null;
  debaterA: string = 'Alice';
  debaterB: string = 'Bob';

  constructor(private apiService: ApiService, private router: Router) { }

  ngOnInit(): void {
    this.apiService.getDebates().subscribe(data => {
      this.debates = data;
    });
  }

  // 1. Ouvre la fenêtre de config quand on clique sur un sujet
  openSetup(debate: Debate): void {
    this.selectedDebate = debate;
  }

  // 2. Ferme la fenêtre
  closeSetup(): void {
    this.selectedDebate = null;
  }

  // 3. Lance le débat et sauvegarde les noms
  startDebate(): void {
    if (!this.selectedDebate || !this.debaterA.trim() || !this.debaterB.trim()) {
      return;
    }

    // On sauvegarde les noms pour la page suivante
    localStorage.setItem('debaterA', this.debaterA);
    localStorage.setItem('debaterB', this.debaterB);
    
    // Par défaut, c'est le joueur A qui commence
    localStorage.setItem('username', this.debaterA);

    this.router.navigate(['/debates', this.selectedDebate.id]);
  }
}