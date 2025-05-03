//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by P on 25/02/2025.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion() -> QuizQuestion?
}
