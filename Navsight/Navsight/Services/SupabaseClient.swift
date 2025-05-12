//
//  SupabaseClient.swift
//  Navsight
//
//  Created by Aneesh on 11/5/25.
//

import Foundation
import Supabase

enum Supabase {
    static let client = SupabaseClient(
        supabaseURL: URL(string: "https://wgqprdheymzeghtttvbv.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndncXByZGhleW16ZWdodHR0dmJ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY4NDY1MzAsImV4cCI6MjA2MjQyMjUzMH0.CSAy_M-XAmoaeAuCSs-i4OsFDfaslrJQwSJ_hb964tQ"
      )
}

